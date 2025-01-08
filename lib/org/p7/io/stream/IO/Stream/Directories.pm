
use v5.40;
use experimental qw[ class ];

use module qw[ org::p7::io::stream ];

use org::p7::util::stream qw[ Stream ];

use Path::Tiny ();

use IO::Stream::Source::FilesFromDirectory;

class IO::Stream::Directories {
    sub files ($, $dir, %opts) {
        $dir = Path::Tiny::path($dir)
            unless blessed $dir;

        Stream->new(
            source => IO::Stream::Source::FilesFromDirectory->new( dir => $dir, %opts )
        )
    }

    sub walk ($, $dir, %opts) {
        __PACKAGE__->files( $dir, %opts )->recurse(
            sub ($c) { $c->is_dir },
            sub ($c) {
                IO::Stream::Source::FilesFromDirectory->new( dir => $c )
            }
        );
    }
}
