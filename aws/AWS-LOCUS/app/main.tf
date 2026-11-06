data "aws_s3_bucket" "static_site_bucket" {
  bucket = "cloudagentra-statis-site52310982"
}

resource "aws_s3_object" "static_site_index_html" {
  bucket       = data.aws_s3_bucket.static_site_bucket.id
  key          = "index.html"
  content_type = "text/html"

  content = <<-HTML
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1.0" />
      <title>AWS Static Website Test</title>
      <style>
        body {
          margin: 0;
          font-family: Arial, sans-serif;
          background-color: #f0f4f8;
          display: flex;
          justify-content: center;
          align-items: center;
          min-height: 100vh;
        }
        .card {
          background: #ffffff;
          border-radius: 10px;
          box-shadow: 0 4px 16px rgba(0,0,0,0.12);
          padding: 48px 56px;
          text-align: center;
          max-width: 540px;
        }
        h1 {
          color: #232f3e;
          font-size: 2rem;
          margin-bottom: 16px;
        }
        p {
          color: #555e6e;
          font-size: 1.15rem;
          line-height: 1.6;
        }
        .badge {
          display: inline-block;
          margin-top: 24px;
          background-color: #ff9900;
          color: #ffffff;
          font-size: 0.85rem;
          font-weight: bold;
          padding: 6px 16px;
          border-radius: 20px;
          letter-spacing: 0.05em;
        }
      </style>
    </head>
    <body>
      <div class="card">
        <h1>AWS Static Website Test</h1>
        <p>Hello, this is a test website hosted on AWS.</p>
        <span class="badge">Hosted on Amazon S3 · ap-south-1</span>
      </div>
    </body>
    </html>
  HTML

  tags = {
    Name  = "index.html"
    Stack = "app"
  }
}

output "website_url" {
  description = "Public URL of the S3 static website"
  value       = "http://cloudagentra-statis-site52310982.s3-website.ap-south-1.amazonaws.com"
}

output "s3_object_key" {
  description = "S3 key of the uploaded index.html object"
  value       = aws_s3_object.static_site_index_html.key
}

output "s3_object_etag" {
  description = "ETag of the uploaded index.html object"
  value       = aws_s3_object.static_site_index_html.etag
}