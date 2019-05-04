#!/usr/bin/env perl

use strict;
use warnings;
use autodie;

use Test::HTML::Tidy::Recursive ();

Test::HTML::Tidy::Recursive->new(
    {
        targets => [ '.', ],
    }
)->run;
