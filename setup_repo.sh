#!/bin/bash

set -e

git clone https://github.com/materialsproject/pymatgen.git /testbed/pymatgen --progress

cd /testbed/pymatgen

git checkout 1abc45936f839369854399369bc966732f85bf08

