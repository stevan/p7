
use v5.40;
use experimental qw[ class ];

use module qw[ org::p7::core::compiler ];

use org::p7::util::stream qw[ Stream ];
use org::p7::core::util   qw[ Logging ];

use Decompiler::Source::Optree;

use Decompiler::Context::Opcode;
use Decompiler::Context::Statement;

use Decompiler::Tools::Events;

use Decompiler::Match::Builder;

class Decompiler {
    field $from :param :reader;

    ADJUST {
        $from = B::svref_2object( $from )
            unless blessed $from;
    }

    method stream {
        Stream->new( source => Decompiler::Source::Optree->new( cv => $from ) )
    }
}
