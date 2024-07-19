use v5.40;
use utf8;
use experimental qw(class);

use HTTP::Status ();
use Cpanel::JSON::XS::Type ();

class Stump 0.01 :isa(Stump::Base) {
    use Stump::Router::Linear;
    use Carp ();

    sub import($class) {
        $_->import for qw(strict warnings utf8);

        feature->import(':5.40');
        builtin->import(':5.40');
        experimental->import('class');

        {
            local $Exporter::ExportLevel = 1;
            HTTP::Status->import(':constants');
            Cpanel::JSON::XS::Type->import();
        }
    }

    ADJUST {
        if (!$self->router) {
            $self->router(Stump::Router::Linear->new);
        }

        Carp::croak 'router must be a Stump::Router subclass' unless $self->router isa Stump::Router;
    }
}

__END__

=encoding utf-8

=head1 NAME

Stump - It's new $module

=head1 SYNOPSIS

    use Stump;

    my $app = Stump->new;
    $app->get('/', sub ($c) {
        $c->text(HTTP_OK, 'Hello Stump!')
    });

    $app->psgi;

=head1 DESCRIPTION

Stump is ...

=head1 LICENSE

Copyright (C) kobaken.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

kobaken E<lt>kentafly88@gmail.comE<gt>

=cut

