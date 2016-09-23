# File uploader API

TODO: Document the principles and API

## Setup

An S3 bucket is required to store the uploaded files. This bucket
should have the minimum possible permissions; list objects, put object,
delete object.

The scripts for easy automation of these tasks can be found in the
[Mojfile S3 bucket setup repo](https://github.com/ministryofjustice/mojfile-s3-bucket-setup)

## Run

```
cp .env.example .env
# ... and update the details in that file with the credentials created above
docker-compose build
docker-compose up
```
## Run outside docker

```bash
bundle exec rackup
```

## Testing

The File uploader is tested using RSpec, mutation testing and rubocop.
To test, run:

```bash
bundle install
bundle exec rake
```