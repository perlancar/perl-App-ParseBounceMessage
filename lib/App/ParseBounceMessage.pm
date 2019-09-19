package App::ParseBounceMessage;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

our %SPEC;

$SPEC{parse_bounce_message} = {
    v => 1.1,
    summary => 'Parse a bounce email message and return a structure',
    args => {
        message_file => {
            summary => 'A file containing a single email message',
            schema => 'filename*',
            description => <<'_',

Dash (`-`) means to get the message from standard input.

_
        },
    },
};
sub parse_bounce_message {
    require File::Slurper;
    require Mail::DeliveryStatus::BounceParser;

    my %args = @_;

    my $message_file = ;
    my $message = $args{message_file} eq '-' ?
        do { local $/; <STDIN> } :
        do { File::Slurper::read_text($args{message_file}) };

    my $bounce = Mail::DeliveryStatus::BounceParser->new($message);

    my @reports = $bounce->reports;
    [200, "OK", {
        addresses       => [$bounce->addresses],
        num_reports     => [scalar(@reports)],
        reports         => [
            map { +{
                reporting_mta   => $_->get('reporting_mta'),
                arrival_date    => $_->get('arrival-date'),
                final_recipient => $_->get('final-recipient'),
                action          => $_->get('action'),
                status          => $_->get('status'),
                diagnostic_code => $_->get('diagnostic-code'),

                email           => $_->get('email'),
                std_reason      => $_->get('std_reason'),
                reason          => $_->get('reason'),
                host            => $_->get('host'),
                smtp_code       => $_->get('smtp_code'),
            } } @reports,
        ],
        orig_message_id => $bounce->orig_message_id,
    }];
}

1;
#ABSTRACT:

=head1 DESCRIPTION

This distribution provides a simple CLI for
L<Mail::DeliveryStatus::BounceParser>.


=head1 SEE ALSO

L<Mail::DeliveryStatus::BounceParser>

=cut
