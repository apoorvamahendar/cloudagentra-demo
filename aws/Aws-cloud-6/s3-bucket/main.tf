# This file intentionally contains no resources for bk-prod-logs-1902082.
#
# The following five resources have been REMOVED from this stack so that
# `tofu apply` will destroy them from state:
#
#   - aws_s3_bucket.bk_prod_logs_1902082                          (bucket: bk-prod-logs-1902082)
#   - aws_s3_bucket_versioning.bk_prod_logs_1902082_versioning
#   - aws_s3_bucket_server_side_encryption_configuration.bk_prod_logs_1902082_sse
#   - aws_s3_bucket_public_access_block.bk_prod_logs_1902082_public_access_block
#   - aws_s3_bucket_ownership_controls.bk_prod_logs_1902082_ownership_controls
#
# The other managed buckets (prod-logs-27738 and prod-logs-62738929) are
# NOT represented here - they are managed by their own resource blocks
# elsewhere in the stack and are completely unaffected by this change.
#
# ⚠️  BEFORE APPLYING:
#   1. Confirm bk-prod-logs-1902082 is empty, OR verify that force_destroy
#      is already set to true in Terraform state - AWS will reject deletion
#      of a non-empty bucket without it.
#   2. Confirm no active CloudTrail, ALB access log, or VPC flow log is
#      currently writing to this bucket.
#   3. This destroy is IRREVERSIBLE - all objects will be permanently lost.