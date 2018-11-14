#!/bin/bash

until nc -z localhost 27017
do
    sleep 1
done
