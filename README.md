# Entity-Relationship-Diagramm-Erzeuger
A simple tool to generate Entity-Relationship-Diagrams based on text input or directly from a PostgreSQL database. The format of the text schema is inspired and based on ["erd" by Andrew Gallant](https://github.com/BurntSushi/erd).

Fork of [edgycircle/erde](https://github.com/edgycircle/erde) with fixes added to suit our development.

## Motivation : Auto generating ERD from database

There are online tools like [genmymodel](https://genmymodel.com) which allows to build ERD diagrams.

We wanted a way where from a database we could draw a picture. This helps an instant update of schema and not making it stale.

Hence we would create make targets that gets triggered which generates schema, from the *Makefile* in our rust aran api server.

## Install
Make sure you have [Graphviz](http://graphviz.org/) installed and available in your `$PATH`.  

Install the gem with `gem install erdf`.

## CLI Usage

~~~txt
erdf version
~~~

~~~txt
erdf file docs/schema.txt docs/schema.png
~~~

~~~txt
bin/erdf database postgres://user:password@localhost/your_database docs/schema.png
~~~

## Text Schema Format
~~~txt
[identities]
id
password
email

[players]
id
name
identity_id

players:identity_id -- identities:id
~~~
