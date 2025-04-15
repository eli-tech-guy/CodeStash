####


resource "aws_iam_user" "secops-ukcdn-mon-users" {
  name = "secops_ukcdn_user"
  path = "/"
}

resource "aws_iam_access_key" "secops-ukcdn-mon-users_key" {
  user = "${aws_iam_user.secops-ukcdn-mon-users.name}"
}

resource "aws_iam_user_policy" "secops-ukcdn-mon-user-policy" {
  name = "secops_ukcdn_s3_access"
  user = "${aws_iam_user.secops-ukcdn-mon-users.name}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:ListAllMyBuckets",
            "Resource": "arn:aws:s3:::*"
        },
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::secops-ukcdn-incoming",
                "arn:aws:s3:::secops-ukcdn-incoming/*"
            ]
        },
        {
            "Effect": "Deny",
            "Action": [
                "s3:DeleteBucket",
                "s3:DeleteBucketPolicy",
                "s3:DeleteBucketWebsite",
                "s3:DeleteObject",
                "s3:DeleteObjectVersion"
            ],
            "Resource": [
                "arn:aws:s3:::secops-ukcdn-incoming",
                "arn:aws:s3:::secops-ukcdn-incoming/*"
            ]
        }
    ]
}
EOF
}

####
## SecOps reptool app user, for accessing S3 buckets and pulling data. Policy should be amended to add additional buckets.

resource "aws_iam_user" "secops-reptool-app-s3user" {
  name = "secops-reptool-app-s3user"
  path = "/"
}

resource "aws_iam_access_key" "secops-reptool-app-s3user_key" {
  user = "${aws_iam_user.secops-reptool-app-s3user.name}"
}

resource "aws_iam_user_policy" "secops-reptool-app-s3user-policy" {
  name = "secops-reptool-app-s3user-policy"
  user = "${aws_iam_user.secops-reptool-app-s3user.name}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:ListAllMyBuckets",
            "Resource": "arn:aws:s3:::*"
        },
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::secops-ukcdn-incoming",
                "arn:aws:s3:::secops-ukcdn-incoming/*"
            ]
        }
    ]
}
EOF
}
