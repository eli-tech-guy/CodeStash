import pg8000
import pandas as pd
import boto3
from openpyxl import Workbook
from office365.sharepoint.client_context import ClientContext
from office365.runtime.auth.user_credential import UserCredential
from datetime import datetime, timedelta
 
def retrieve_data_from_db(connection, table_name):
    cursor = connection.cursor()
    cursor.execute(f"SELECT * FROM {table_name}")
    rows = cursor.fetchall()
    columns = [desc[0] for desc in cursor.description]
    cursor.close()
    return columns, rows
 
def write_data_to_excel(columns, rows, excel_file_path):
    df = pd.DataFrame(rows, columns=columns)
    df.to_excel(excel_file_path, index=False)
    print(f"Data successfully written to {excel_file_path}")
 
def upload_to_s3(file_path, bucket_name, s3_key):
    s3 = boto3.client('s3')
    try:
        s3.upload_file(file_path, bucket_name, s3_key)
        print(f"File successfully uploaded to S3 at {bucket_name}/{s3_key}")
    except Exception as e:
        print(f"Failed to upload file to S3: {e}")
 
def upload_to_sharepoint(file_path, site_url, folder_url, username, password):
    try:
        ctx = ClientContext(site_url).with_credentials(UserCredential(username, password))
        if not ctx:
            print("Failed to authenticate to SharePoint.")
            return
        target_folder = ctx.web.get_folder_by_server_relative_url(folder_url)
        if not target_folder:
            print(f"Folder '{folder_url}' not found.")
            return
        with open(file_path, 'rb') as content_file:
            file_name = file_path.split("/")[-1]
            target_file = target_folder.upload_file(file_name, content_file.read()).execute_query()
            if target_file is not None:
                print(f"File successfully uploaded to SharePoint: {target_file.serverRelativeUrl}")
            else:
                print("Upload to SharePoint failed: target file is None.")
    except Exception as e:
        print(f"Failed to upload file to SharePoint: {e}")
 
def manage_outputcombined_versions(connection):
    cursor = connection.cursor()
    cursor.execute("""
        SELECT table_name
        FROM information_schema.tables
        WHERE table_name LIKE 'outputcombined_%'
        ORDER BY table_name DESC;
    """)
    result = cursor.fetchall()
    versions = [row[0] for row in result]
 
    if len(versions) > 3:
        for table_to_drop in versions[3:]:
            cursor.execute(f"DROP TABLE IF EXISTS {table_to_drop} CASCADE")
            cursor.execute(f"DROP TYPE IF EXISTS {table_to_drop}_type CASCADE")
            print(f"Dropped old version of table: {table_to_drop}")
 
    new_version_table = f"outputcombined_{pd.Timestamp.now().strftime('%Y%m%d%H%M%S')}"
    cursor.execute(f"DROP TYPE IF EXISTS {new_version_table}_type CASCADE")
 
    cursor.execute(f"""
        CREATE TABLE {new_version_table} AS
        SELECT
            ddi."rbacGroupName",
            ddi."computerDnsName",
            ddi."osPlatform",
            ddi."avSignatureVersion",
            ddi."avEngineVersion",
            ddi."avPlatformVersion",
            TO_CHAR(ddi."lastSeenTime"::timestamp, 'DD Mon YYYY HH24:MI:SS') AS "lastSeenTime",
            ddi."avIsSignatureUpToDate",
            ddi."avIsEngineUpToDate",
            ddi."avIsPlatformUpToDate",
            ddi."cloudProtectionState",
            dm."id",
            dm."lastIpAddress",
            TO_CHAR(dm."lastSeen"::timestamp, 'DD Mon YYYY HH24:MI:SS') AS "lastSeen",
            dm."agentVersion",
            dm."healthStatus",
            dm."onboardingStatus",
            CASE 
                WHEN dm."lastSeen"::timestamp < NOW() - INTERVAL '24 hours' THEN dm."computerDnsName"
                ELSE NULL
            END AS "NotSeen24h"
        FROM
            defenderdeviceinfo ddi
        JOIN
            defendermachines dm
        ON
            ddi.id = dm.id;
    """)
 
    print(f"Created new version of table: {new_version_table}")
    connection.commit()
    return new_version_table
 
def lambda_handler(event, context):
    connection = pg8000.connect(
        user="postgres",
        password="~t8:3o8op$*)1}e+Erj7mLd[?vD*",
        host="sip-automation-instance-1.cxekmmq8m71d.eu-west-2.rds.amazonaws.com",
        port=5432,
        database="postgres"
    )
 
    excel_file_path = '/tmp/defender_output.xlsx'
    s3_bucket_name = 'sip-ms-defender-output'
    s3_key = 'defender_output.xlsx'
    sharepoint_site_url = "https://tsbcloud.sharepoint.com/sites/CISOAutomation"
    sharepoint_folder_url = "/sites/CISOAutomation/Shared%20Documents/Reports"
    sharepoint_username = "elishua.mcpherson@tsb.co.uk"
    sharepoint_password = "London@20.24"
 
    try:
        new_table_name = manage_outputcombined_versions(connection)
        columns, rows = retrieve_data_from_db(connection, new_table_name)
        write_data_to_excel(columns, rows, excel_file_path)
        upload_to_s3(excel_file_path, s3_bucket_name, s3_key)
        upload_to_sharepoint(excel_file_path, sharepoint_site_url, sharepoint_folder_url, sharepoint_username, sharepoint_password)
    except Exception as e:
        print(f"Error in the processing pipeline: {e}")
    finally:
        connection.close()
        print("Operation completed. The Excel file has been created, uploaded to S3 and SharePoint.")