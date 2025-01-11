
use v5.40;
use experimental qw[ class ];

use module qw[ org::p7::core::compiler ];

use org::p7::core::util     qw[ Logging ];
use org::p7::util::function qw[ Predicate ];


class Decompiler::Match::Builder :isa(Stream::Match::Builder) {
    method build_matcher (%opts) {

        if (my $name = delete $opts{name}) {
            $opts{predicate} = Predicate->new( f => sub ($op) {
                $op->name eq $name;
            });
        }
        elsif (my $type = delete $opts{type}) {
            $opts{predicate} = Predicate->new( f => sub ($op) {
                $op->type eq $type;
            });
        }

        return $self->SUPER::build_matcher( %opts );
    }

}
