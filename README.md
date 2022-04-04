# PostgreSQL Recurrent Events

This repository contains PostgreSQL functions to help you develop applications that contain calendar events at their core.
The core of this repository also has a C extension that helps parse rules and generate events based on them.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine and test it.

### Prerequisites

This is an alpha version of the extension, so there is no instruction on how to run it in production.
You can try it in the docker.

# How to run
```shell
docker build . -t recurrent-event
docker-compose up 
```

```shell
su postgres
cat /home/script/*.sql | psql postgres
cat /home/script/event/*.sql | psql postgres
```
If you would like to see the capabilities of this extension, you can see the file [example_of_work.sql](example_of_work.sql)

### Installing

Now it has not got script for automate installing to your database.
For installing you need to
1. Install pg_rrule extension. [Link](https://github.com/Karpovich-alex/pg_rrule)
2. Run all sql files from [./src](./src) expect [./scr/test](./src/test) folder

## Running the tests

There is no automatic tests build-in in PostgreSQL, so you can run scripts from [.src/event/test](.src/event/test) dir.

### Coding style

Will be formatted according to [this](https://about.gitlab.com/handbook/business-technology/data-team/platform/sql-style-guide/) manual.

## Deployment
**THIS IS AN ALPHA VERSION!**

You can use docker to test is.

## Built With

* [pg_rrule](https://github.com/Karpovich-alex/pg_rrule) - C-extension for parsing iCalendar recurrent rules for events.

## Contributing

Please read [CONTRIBUTING.md](./CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.

## Authors

* [**Karpovich Alexandr**](https://github.com/Karpovich-alex) - *Initial work* 

See also the list of [contributors](https://github.com/your/project/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

