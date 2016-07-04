[![Dependency Status](https://gemnasium.com/badges/github.com/renuo/renuo-upload-signing.svg)](https://gemnasium.com/github.com/renuo/renuo-upload-signing) [![Build Status](https://travis-ci.org/renuo/renuo-upload-signing.svg?branch=master)](https://travis-ci.org/renuo/renuo-upload-signing) [![Build Status](https://travis-ci.org/renuo/renuo-upload-signing.svg?branch=develop)](https://travis-ci.org/renuo/renuo-upload-signing) [![Build Status](https://travis-ci.org/renuo/renuo-upload-signing.svg?branch=testing)](https://travis-ci.org/renuo/renuo-upload-signing)

# Renuo Upload Signing

Renuo Upload Signing is a small Sinatra application which generates policies for 
uploading to S3. It stores all the apps and their api keys that use Renuo Upload.

## Important Links

* https://github.com/renuo/renuo-upload-signing

## Ruby

This application requires:

- Ruby 2.3.0

## Installation

```sh
git clone git@github.com:renuo/renuo-upload-signing.git
cd renuo-upload-signing
bin/setup
```

## Configuration

Copy the database and application example-config files and fill out the missing values.

```sh
bin/setup
```

Edit the config/.env after bin/setup.

The string that contains the api keys and the apps they belong to must be stored in the 
env var (in config/.env) called API_KEYS. It has to be in the following format:

```sh
{"key":"some_key", "private_key": "some-private", "app_name":"some_name","env": "some_env"};{"key":"some_key", "private_key": "some-private", "app_name":"some_name","env": "some_env"};...
```

## Tests / Code Linting / Vulnerability Check

### Everything

```sh
bin/check
```

This runs

* keyword check (console.log, T0D0, puts, ...)
* rubocop
* scsslint
* tslint
* coffeelint
* brakeman
* rspec

### Rspec Only

```sh
rspec
```

## Run

```sh
bin/run
```

Once you have the application running locally, you can simulate a POST request being made by using the
following cURL command in your terminal (replace the port if it's different for you):

```sh
curl -v --data "api_key=12345678" http://localhost:9292/generate_policy
```

## Problems?

If problems should arise, either contact Nicolas Eckhart, Cyril Kyburz, Lukas Elmer or Simon Huber.

![Nicolas Eckhart](http://www.gravatar.com/avatar/742cec893c283daf4a3c287ef2681599)
![Cyril Kyburz](http://www.gravatar.com/avatar/4f522497d9145b89661c381d5fd7a50c)
![Lukas Elmer](https://www.gravatar.com/avatar/697b8e2d3bde4d895eca4fe2dcfe9239)
![Simon Huber](https://www.gravatar.com/avatar/af962bd3439b7473d4344a0f42c3087c)

## MIT License

Coypright 2016 [Renuo AG](https://www.renuo.ch/). See [LICENSE](LICENSE) file.
