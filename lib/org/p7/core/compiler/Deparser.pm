
use v5.40;
use experimental qw[ class ];

use module qw[ org::p7::core::compiler ];

use org::p7::core::util qw[ Logging ];

use Deparser::Observer;
use Deparser::Event;

use Deparser::Tree;
use Deparser::Tree::Builder;

class Deparser {
    field $stream :param :reader;

    field $tree_builder;
    field @statements;
    field @stack;

    ADJUST {
        $tree_builder = Deparser::Tree::Builder->new;
    }

    method flush_stack {
        my @events = reverse @stack;
        @stack = ();
        return @events;
    }

    method parse {

        my ($root, $error);
        try {
            $stream->foreach(sub ($op) {
                $root //= $op;
                $tree_builder->on_next( $_ ) foreach $self->parse_op( $op );
            });
        } catch ($e) {
            $error = $e;
        }

        if ($error) {
            $tree_builder->on_error($error);
            return $tree_builder->error;
        }

        unless ($root) {
            $tree_builder->on_error("No root found!");
            return $tree_builder->error;
        }

        if (DEBUG) {
            LOG $self, '=============================================================';
            LOG $self, "-- BEFORE(statmements) --------------------------------------";
            LOG $self, join ', ' => map { '['.(join ', ' => @$_).']' } @statements;
            LOG $self, "-- BEFORE(stack) --------------------------------------------";
            LOG $self, "  - ".join "\n  - " => @stack;
        }

        $tree_builder->on_next($_)
            foreach $self->unwind_events( $self->flush_stack );

        if (DEBUG) {
            LOG $self, "-- AFTER(statmements) ---------------------------------------";
            LOG $self, join ', ' => map { '['.(join ', ' => @$_).']' } @statements;
            LOG $self, "-- AFTER(stack) ---------------------------------------------";
            LOG $self, "  - ".join "\n  - " => @stack;
            LOG $self, '=============================================================';
        }

        $tree_builder->on_completed;

        return $tree_builder->build;
    }

    method parse_op ($op) {
        if (DEBUG) {
            LOG $self, '>>> PARSER ==================================================';
            LOG $self, "GOT          : $op";
            LOG $self, '-------------------------------------------------------------';
            LOG $self, "DEPTH        : ".$op->depth;
            LOG $self, "DESCENDANTS? : ".($op->has_descendents ? 'yes' : 'no');
            LOG $self, "SIBLING?     : ".($op->has_sibling     ? (sprintf 'yes(%s)', ${ $op->op->sibling }) : 'no');
            LOG $self, "-- BEFORE(statmements) --------------------------------------";
            LOG $self, join ', ' => map { '['.(join ', ' => @$_).']' } @statements;
            LOG $self, "-- BEFORE(stack) --------------------------------------------";
            LOG $self, "  - ".join "\n  - " => @stack;
        }

        my @events;

        if ($op->name eq 'leavesub') {
            my $event = Deparser::Event::EnterSubroutine->new( op => $op );
            push @stack  => $event;
            push @events => $event;
        }
        elsif ($op->name eq 'lineseq') {
            my $event = Deparser::Event::EnterStatementSequence->new( op => $op );
            push @stack  => $event;
            push @events => $event;
            push @statements => [];
        }
        elsif ($op->name eq 'argcheck' && $op->is_null) {
            my $event = Deparser::Event::EnterPreamble->new( op => $op );
            push @stack  => $event;
            push @events => $event;
        }
        elsif ($op->name eq 'nextstate') {
            my $event = Deparser::Event::EnterStatement->new( op => $op );
            if ($statements[-1]->@*) {
                my $prev = pop $statements[-1]->@*;
                push @events => $self->unwind_stack($event);
            }

            push $statements[-1]->@* => $event;
            push @stack  => $event;
            push @events => $event;
        }
        else {
            my $event;
            if ($op->has_descendents) {
                $event = Deparser::Event::EnterExpression->new( op => $op );
            }
            else {
                $event = Deparser::Event::Terminal->new( op => $op );
            }

            if ($event->op->depth < $stack[-1]->op->depth) {
                DEBUG && LOG $self, "We need to unwind the expression";
                push @events => $self->unwind_stack($event);
            }

            push @stack  => $event;
            push @events => $event;
        }

        if (DEBUG) {
            LOG $self, '';
            LOG $self, "-- AFTER(statmements) ---------------------------------------";
            LOG $self, join ', ' => map { '['.(join ', ' => @$_).']' } @statements;
            LOG $self, "-- AFTER(stack) ---------------------------------------------";
            LOG $self, "  - ".join "\n  - " => @stack;
            LOG $self, "~~ EVENTS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~";
            LOG $self, "  - ".join "\n  - " => @events;
            LOG $self, '=============================================================';
        }

        return @events;
    }

    method unwind_stack ($next) {
        DEBUG && LOG $self, '-- Unwind Stack ----------------------------------------';
        my @events;

        while (@stack) {
            DEBUG && LOG $self, ">> CANDIDATE: ",$stack[-1];
            DEBUG && LOG $self, sprintf '>> curr: %d next(parent): %d',$stack[-1]->op->addr, $next->op->parent->addr;

            last if $stack[-1]->op->addr == $next->op->parent->addr;

            my $candidate = pop @stack;
            push @events => $candidate;
        }

        return $self->unwind_events(@events);
    }

    method unwind_events (@events) {
        DEBUG && LOG $self, '-- Unwind Events ---------------------------------------';
        DEBUG && LOG $self, ">> Got ".(scalar @events)." events to unwind:\n>>  - ".(join "\n>>  - " => @events);

        my @unwound;
        foreach my $event (@events) {
            DEBUG && LOG $self, "?? Checking $event";

            if ($event isa Deparser::Event::Terminal) {
                DEBUG && LOG $self, ".. Got Terminal($event)";
                next; # do nothing, the event was already emitted
            }
            elsif ($event isa Deparser::Event::EnterStatementSequence) {
                DEBUG && LOG $self, ".. Got EnterStatementSequence($event), dropping statements...";
                my $drop = pop @statements;
                DEBUG && LOG $self, "!! dropping !!",join ', ' => @$drop;
            }

            push @unwound => $event->create_compliment;
        }

        DEBUG && LOG $self, ">> Got ".(scalar @unwound)." unwound events:\n>>  - ".(join "\n>>  - " => @unwound);

        DEBUG && LOG $self, '--------------------------------------------------------';
        return @unwound;
    }

}


