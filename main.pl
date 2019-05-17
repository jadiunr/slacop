use strict;
use warnings;
use utf8;

use YAML::Tiny;
use Slack::RTM::Bot;

use lib 'lib';
use Slack::WebAPI;

my $config = YAML::Tiny->read('config.yml')->[0];
my $rtm = Slack::RTM::Bot->new(token => $config->{token});
my $api = Slack::WebAPI->new(
  token => $config->{token},
  username => $config->{username},
  icon_url => $config->{icon_url}
);

$rtm->on({subtype => 'message_deleted'}, sub {
  my $response = shift;
  my $channel = $response->{channel};
  my $text = $response->{previous_message}{text};
  my $user = $response->{previous_message}{user};

  $api->post_message(
    channel => $channel,
    text => "<\@${user}> deleted the message.\n\n${text}"
  );
});

$rtm->start_RTM(sub {while (1) {sleep 1}});