
use v5.40;
use experimental qw[ class ];

use module qw[ org::p7::io::stream ];

use org::p7::util::stream qw[ Stream ];

use Path::Tiny ();

use IO::Stream::Source::BytesFromHandle;
use IO::Stream::Source::LinesFromHandle;

class IO::Stream::Files {
    sub bytes ($, $fh, %opts) {
        $fh = Path::Tiny::path($fh)->openr
            unless blessed $fh
                || ref $fh eq 'GLOB';

        Stream->new(
            source => IO::Stream::Source::BytesFromHandle->new( fh => $fh, %opts ),
        )
    }

    sub lines ($, $fh, %opts) {
        $fh = Path::Tiny::path($fh)->openr
            unless blessed $fh
                || ref $fh eq 'GLOB';

        Stream->new(
            source => IO::Stream::Source::LinesFromHandle->new( fh => $fh, %opts )
        )
    }
}
