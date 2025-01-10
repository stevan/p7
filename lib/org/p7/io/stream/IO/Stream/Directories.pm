
use v5.40;
use experimental qw[ class ];

use module qw[ org::p7::io::stream ];

use org::p7::util::stream qw[ Stream ];
use org::p7::core::util   qw[ Logging ];

use importer 'Path::Tiny' => 'path';

use IO::Stream::Source::FilesFromDirectory;

class IO::Stream::Directories {
    sub files ($class, $dir, %opts) {
        LOG $class, { dir => $dir, opts => \%opts } if DEBUG;

        $dir = path($dir) unless blessed $dir;

        Stream->new(
            source => IO::Stream::Source::FilesFromDirectory->new( dir => $dir, %opts )
        )
    }

    sub walk ($class, $dir, %opts) {
        LOG $class, { dir => $dir, opts => \%opts } if DEBUG;

        __PACKAGE__->files( $dir, %opts )->recurse(
            sub ($c) { $c->is_dir },
            sub ($c) {
                IO::Stream::Source::FilesFromDirectory->new( dir => $c )
            }
        );
    }
}
