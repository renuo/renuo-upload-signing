# Renuo Upload Signing

Renuo Upload Signing is a small Sinatra application which generates policies for 
uploading to S3. It stores all the apps and their api keys that use Renuo Upload.

## Domains

### Master

https://renuo-upload-signing-master.herokuapp.com

### Develop

https://renuo-upload-signing-develop.herokuapp.com

### Testing

https://renuo-upload-signing-testing.herokuapp.com

## Ruby on Rails

This application requires:

- Ruby 2.2.0

## Installation

```sh
git clone git@git.renuo.ch:renuo/renuo-upload-signing.git
cd renuo-upload-signing
bundle install
```

## Configuration

Copy the database and application example-config files and fill out the missing values.
They can be found in the Renuo Redmine Wiki of this project.

```sh
cp config/example.env config/.env
```

## Tests

### Run Tests

```sh
rspec
```

## Run

```sh
rackup
```

## Problems?

If problems should arise, either contact Nicolas Eckhart, Cyril Kyburz or Lukas Elmer.

![Nicolas Eckhart](http://www.gravatar.com/avatar/742cec893c283daf4a3c287ef2681599)
![Cyril Kyburz](http://www.gravatar.com/avatar/4f522497d9145b89661c381d5fd7a50c)
![Lukas Elmer](https://www.gravatar.com/avatar/697b8e2d3bde4d895eca4fe2dcfe9239)

## Copyright

Coypright 2015 [Renuo GmbH](https://www.renuo.ch/).