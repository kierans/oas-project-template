#! /bin/sh

# Take a template and a blob of data and render it
echo $2 | hbs $1 -i -s
