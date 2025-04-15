import requests 
import boto3
import xmltodict
import json
import pg8000
import re
import uuid
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry
 
def sanitize_xml_content(xml_content):
    invalid_xml_re = re.compile(r'[\x00-\x08\x0b\x0c\x0e-\x1f\x7f-\x84\x86-\x9f]')
    return invalid_xml_re.sub('', xml_content)
 
def create_session_with_retries():
    session = requests.Session()
    retries = Retry(
        total=5,
        backoff_factor=1,
        status_forcelist=[502, 503, 504],
        allowed_methods=["HEAD", "GET", "OPTIONS", "POST"]
    )
    adapter = HTTPAdapter(max_retries=retries)
    session.mount('https://', adapter)
    session.mount('http://', adapter)
    return session
 
def get_report_id(username, password, url=None):
    if url is None:
        url = ("https://qualysapi.qg2.apps.qualys.eu/api/2.0/fo/asset/host/vm/detection/?action=list&show_qds=1&qds_min=1&qds_max=20&show_qds_factors=1")
    session = create_session_with_retries()
    try:
        with session.post(url, auth=(username, password), headers={"X-Requested-With": "curl"}, timeout=(90)) as response:
            print("This is the response status code: " + str(response.status_code))
            response.raise_for_status()
            xml_data = response.text
            json_data = xmltodict.parse(xml_data)
            json_dict = json.loads(json.dumps(json_data))
            print("This is the response content in JSON format: ", json.dumps(json_dict, indent=2))
            if "TEXT" in json_dict and "1000 record limit exceeded" in json_dict["TEXT"]:
                next_url = json_dict["TEXT"].split("Use URL to get next batch of results.")[1].strip()
                print(f"Fetching next batch of results from: {next_url}")
                get_report_id(username, password, next_url)
            else:
                return json_dict
    except requests.exceptions.HTTPError as http_err:
        print(f"HTTP error occurred: {http_err}")
    except requests.exceptions.ConnectTimeout as e:
        print(f"Connection timed out: {e}")
    except requests.exceptions.RequestException as e:
        print(f"Request failed: {e}")
    except xmltodict.expat.ExpatError as e:
        print(f"XML Parsing failed: {e}")
    return None
 
def insert_data_into_db(connection, table_name, all_data):
    cursor = connection.cursor()
    for item in all_data:
        columns = [key for key in item.keys() if key != 'ipAddresses']
        values = [str(item[col]).replace("'", "''") for col in columns]
        columns_str = ", ".join([f'"{col}"' for col in columns])
        values_str = ", ".join([f"'{val}'" for val in values])
        update_str = ", ".join([f'"{col}" = EXCLUDED."{col}"' for col in columns])
        if 'id' not in item or not item['id']:
            item['id'] = str(uuid.uuid4())
        insert_query = (
            f"INSERT INTO {table_name} ({columns_str}) VALUES ({values_str}) "
            f"ON CONFLICT (id) DO UPDATE SET {update_str}"
        )
        cursor.execute(insert_query)
    connection.commit()
    cursor.close()
 
def lambda_handler(event, context):
    username = "tsbba5em1"
    password = ""
    s3_bucket = "sip-qualys-reports"
    all_data = get_report_id(username, password)
    if all_data:
        connection = pg8000.connect(
            user="postgres",
            password="~",
            host="sip-automation-instance-1.cxekmmq8m71d.eu-west-2.rds.amazonaws.com",
            port=5432,
            database="postgres" 
        )
        cursor = connection.cursor()
        cursor.execute("SELECT table_name FROM information_schema.tables WHERE table_name LIKE 'qualys_api_queries%'")
        tables = cursor.fetchall()
        table_number = max([int(re.search(r'\d+', t[0]).group()) for t in tables], default=0) + 1
        table_name = f'qualys_api_queries{table_number}'
 

        create_table_query = (
            f"CREATE TABLE IF NOT EXISTS {table_name} ("
            "id UUID PRIMARY KEY, "
            "data JSONB NOT NULL)"
        )
        cursor.execute(create_table_query)
        connection.commit()
 
        insert_data_into_db(connection, table_name, all_data)
        connection.close()
