#!/usr/bin/perl

use strict;
use warnings;

use IO::All;
use JSON::MaybeXS qw(encode_json);

use utf8;

use Shlomif::Screenplays::EPUB;

my $obj = Shlomif::Screenplays::EPUB->new;
$obj->run;

my $gfx = $obj->gfx;
my $filename = $obj->filename;
my $out_fn = $obj->out_fn;
my $target_dir = $obj->target_dir;

my $base = 'Blue-Rabbit-Log-part-';
foreach my $part ($filename =~ /\A\Q$base\E([0-9]+)/g)
{
    my $epub_basename = $base.$part;
    my $json_filename = "$epub_basename.json";
    io->file($target_dir . '/' . $json_filename)->utf8->print(
        encode_json(
            {
                filename => $epub_basename,
                title => qq/The Blue Rabbit Log - $part/,
                authors =>
                [
                    {
                        name => "Shlomi Fish",
                        sort => "Fish, Shlomi",
                    },
                ],
                contributors =>
                [
                    {
                        name => "Shlomi Fish",
                        role => "oth",
                    },
                ],
                cover => "images/$gfx",
                rights => "Creative Commons Attribution Noncommercial ShareAlike Unported (CC-by-3.0)",
                publisher => 'http://www.shlomifish.org/',
                language => 'en-GB',
                subjects => [ 'FICTION/Horror', 'FICTION/Humorous', 'FICTION/Masups', ],
                identifier =>
                {
                    scheme => 'URL',
                    value => 'http://www.shlomifish.org/humour/TOWTF/',
                },
                contents =>
                [
                    {
                        "type" => "toc",
                        "source" => "toc.html"
                    },
                    {
                        type => 'text',
                        source => "scene-*.xhtml",
                    },
                ],
                toc  => {
                    "depth" => 2,
                    "parse" => [ "text", ],
                    "generate" => {
                        "title" => "Index"
                    },
                },
                guide => [
                    {
                        type => "toc",
                        title => "Index",
                        href => "toc.html",
                    },
                ],
            },
        ),
    );

    my $orig_dir = io->curdir->absolute . '';

    my $epub_fn = $epub_basename . ".epub";

    {
        chdir ($target_dir);

        my @cmd = ("ebookmaker", "--output", $epub_fn, $json_filename);
        print join(' ', @cmd), "\n";
        system (@cmd)
            and die "cannot run ebookmaker - $!";

        chdir ($orig_dir);
    }

    io->file("$target_dir/$epub_fn") > io->file($out_fn);
}
