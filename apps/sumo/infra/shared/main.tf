provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "s3" {
    bucket = "sumo-shared-provisioning-tf-state"
    key    = "tf-state"
    region = "us-west-2"
  }
}

####


#####################################################################
# S3 buckets for user media
#####################################################################
resource "aws_s3_bucket" "logs" {
  bucket = "sumo-user-media-logs"
  acl    = "log-delivery-write"
}

module "sumo-user-media-dev-bucket" {
    bucket_name = "sumo-user-media-dev"
    iam_policy_name = "SUMOUserMediaDev"
    logging_bucket_id = "${aws_s3_bucket.logs.id}"
    logging_prefix = "dev-logs/"
    region = "${var.region}"
    source = "./user_media_s3"
}

module "sumo-user-media-stage-bucket" {
    bucket_name = "sumo-user-media-stage"
    iam_policy_name = "SUMOUserMediaStage"
    logging_bucket_id = "${aws_s3_bucket.logs.id}"
    logging_prefix = "stage-logs/"
    region = "${var.region}"
    source = "./user_media_s3"
}

module "sumo-user-media-prod-bucket" {
    bucket_name = "sumo-user-media-prod"
    iam_policy_name = "SUMOUserMediaProd"
    logging_bucket_id = "${aws_s3_bucket.logs.id}"
    logging_prefix = "prod-logs/"
    region = "${var.region}"
    source = "./user_media_s3"
}

#####################################################################
# S3 buckets for static media
#####################################################################

resource "aws_s3_bucket" "static-media-logs" {
  bucket = "sumo-static-media-logs"
  acl    = "log-delivery-write"
}

module "sumo-static-media-stage-bucket" {
    bucket_name = "sumo-stage-media"
    iam_policy_name = "SUMOStaticMediaStage"
    logging_bucket_id = "${aws_s3_bucket.static-media-logs.id}"
    logging_prefix = "stage-logs/"
    region = "${var.region}"
    source = "./static_media_s3"
}

module "sumo-static-media-prod-bucket" {
    bucket_name = "sumo-prod-media"
    iam_policy_name = "SUMOStaticMediaProd"
    logging_bucket_id = "${aws_s3_bucket.static-media-logs.id}"
    logging_prefix = "prod-logs/"
    region = "${var.region}"
    source = "./static_media_s3"
}

#####################################################################
# user media CDN
#####################################################################
module "sumo-user-media-dev-cf" {
    source = "./cloudfront"

    acm_cert_arn = "arn:aws:acm:us-east-1:236517346949:certificate/d8711106-680f-42d3-b9b5-e10b39381c7e"
    aliases = ["dev-cdn.sumo.mozilla.net", "dev-cdn.sumo.moz.works"]
    comment = "Dev CDN for SUMO user media"
    distribution_name = "SUMOMediaDevCDN"
    domain_name = "sumo-user-media-dev.s3-website-us-west-2.amazonaws.com"
}

module "sumo-user-media-stage-cf" {
    source = "./cloudfront"

    acm_cert_arn = "arn:aws:acm:us-east-1:236517346949:certificate/c882842a-b244-4a32-896a-0b5dace0c3a4"
    aliases = ["stage-cdn.sumo.mozilla.net", "stage-cdn.sumo.moz.works"]
    comment = "Stage CDN for SUMO user media"
    distribution_name = "SUMOMediaStageCDN"
    domain_name = "sumo-user-media-stage.s3-website-us-west-2.amazonaws.com"
}

module "sumo-user-media-prod-cf" {
    source = "./cloudfront"

    acm_cert_arn = "arn:aws:acm:us-east-1:236517346949:certificate/243ac46e-bf75-4daa-b8c1-6043de87959d"
    aliases = ["prod-cdn.sumo.mozilla.net", "prod-cdn.sumo.moz.works"]
    comment = "Prod CDN for SUMO user media"
    distribution_name = "SUMOMediaProdCDN"
    domain_name = "sumo-user-media-prod.s3-website-us-west-2.amazonaws.com"
}

#####################################################################
# static media CDN
#####################################################################
module "sumo-static-media-dev-cf" {
    source = "./cloudfront_static_media"

    acm_cert_arn = "arn:aws:acm:us-east-1:236517346949:certificate/2d7eb850-9214-49b5-9024-ec857ea0bf5c"
    aliases = ["static-media-dev-cdn.sumo.mozilla.net", "static-media-dev-cdn.sumo.moz.works"]
    comment = "Dev CDN for SUMO static media"
    distribution_name = "SUMOStaticMediaDevCDN"
    domain_name = "dev.sumo.moz.works"
}

module "sumo-static-media-stage-cf" {
    source = "./cloudfront_static_media"

    acm_cert_arn = "arn:aws:acm:us-east-1:236517346949:certificate/11d5784f-997e-4271-a6d5-2cfeb8dccb27"
    aliases = ["static-media-stage-cdn.sumo.mozilla.net", "static-media-stage-cdn.sumo.moz.works"]
    comment = "Stage CDN for SUMO static media"
    distribution_name = "SUMOStaticMediaStageCDN"
    domain_name = "stage-tp.sumo.moz.works"
}

module "sumo-static-media-prod-cf" {
    source = "./cloudfront_static_media"

    acm_cert_arn = "arn:aws:acm:us-east-1:236517346949:certificate/a5cc5ef0-7781-4108-8e70-34d8358ea5cc"
    aliases = ["static-media-prod-cdn.sumo.mozilla.net", "static-media-prod-cdn.sumo.moz.works"]
    comment = "Prod CDN for SUMO static media"
    distribution_name = "SUMOStaticMediaProdCDN"
    domain_name = "support.mozilla.org"
}

#####################################################################
# failover CDN
#####################################################################
module "sumo-failover-cf" {
    source = "./cloudfront_failover"

    acm_cert_arn = "arn:aws:acm:us-east-1:236517346949:certificate/c677a888-a2ee-4486-92f5-cc99355624b7"
    aliases = ["support.mozilla.org", "support.mozilla.com", "failover-cdn.sumo.moz.works"]
    comment = "Frankfurt failover CDN"
    distribution_name = "SUMOFailoverCDN"
    domain_name = "prod-frankfurt.sumo.moz.works"
    min_ttl = 0
    max_ttl = 28800     /* 8 hours */
    default_ttl = 14400 /* 4 hours */
}
