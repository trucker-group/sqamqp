# Sqamqp

sqamqp это gem, который содержит набор логики для работы приложения с amqp (RabbitMQ) 

в качестве клиента amqp используется [bunny](https://github.com/ruby-amqp/bunny)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sqamqp', git: 'ssh://git@gitlab2.sqtools.ru:10022/sqerp/sqamqp.git'
```

And then execute:

    $ bundle

## Usage

### настройки коннекта к amqp

в .env проекта разместить переменные с настройками подключения: 

```
AMQP_HOST=192.168.1.1
AMQP_USER=stage
AMQP_PASSWORD=stage
AMQP_VHOST=vhost
AMQP_POOL=10
```

Если этого не сделать, то будут использованы значения по умолчанию, подходящие для локально настроенного сервера amqp без использования virtual_host

### строка подключения в формате amqp:

```ruby
Sqamqp::Connection.connection_string #=> 'amqp://stage:stage@192.168.1.1/vhost'
```


###  Публикация сообщений 

Для соединения с сервером amqp нужно сделать вызов: 

```ruby
Sqamqp::Connection.establish_connection do |config|
  config.log_file = 'log/bunny.log' # по умолчанию STDOUT
  config.log_level = Logger::DEBUG # по умолчанию Logger::WARN
end
```


Можно вызывать этот метод перед каждой публикацией, а можно один раз при инициализации приложения.

Модуль  `Sqamqp::Publisher` содержит базу для публикации сообщений. Сейчас поддерживаются персистентные топик сообщения (`persistent: true, routing_key: 'route'`)

Пример использования: 

```ruby
Sqamqp::Connection.establish_connection

class MyPublihser
  include Sqamqp::Publisher

  attr_reader :employee, :event

  EXCHANGE = :employee_events

  def initialize(employee, event)
    @employee = employee
    @event = "employee.#{event}"
  end

  def configure_channel(channel)
    channel.topic(EXCHANGE, durable: true)
  end

  def payload
    { id: employee.id, first_name: employee.first_name }
  end
end

MyPublihser.new(employee).publish
```

### Sneakers

Для обработки сообщений служит специальный гем [sneakers](https://github.com/jondot/sneakers)

Структура воркера похожа на sidekiq, но только вместо redis - amqp.

воркер и раннер Sneakers конфигурируется целой кучей параметров, вот пример: 

```ruby
require 'json'
require 'sneakers'
require 'sqamqp'
require_relative '../app/workers/sn_employee_subscriber'
require 'sneakers/handlers/maxretry'

Sneakers.configure(
  amqp: Sqamqp::Connection.connection_string,
  daemonize: false,
  log: STDOUT,
  handler: Sneakers::Handlers::Maxretry, workers: 3 
)
Sneakers.logger.level = Logger::INFO

class SnEmployeeSubscriber
  include Sneakers::Worker
  QUEUE_NAME = 'squad_employee_changed'.freeze
  from_queue QUEUE_NAME,
             durable: true,
             ack: true,
             prefetch: 10,
             exchange: :employee_events,
             exchange_type: :topic,
             routing_key: 'employee.*',
             arguments: { :'x-dead-letter-exchange' => "#{QUEUE_NAME}-retry" }

  # два метода для обработки сообщения:

  # # простой
   def work(msg)
     p 'GOT MESSAGE!'
     p JSON.parse(msg)
     #тут нужно быстро выполнить джоб, по дефолту 5 секунд, иначе сообщение # уйдет в retry
     ack!
   end

  # и с расширенными парамсами, например можно посмотреть ключ(роут) события
  def work_with_params(msg, delivery_info, metadata)
    p 'GOT MESSAGE WITH PARAMS!'
    # p JSON.parse(msg)
    p delivery_info # delivery_info[:routing_key]  == "employee.new"
    p metadata
    ack!
  end
end

```


### Дополнительные параметры соединения

`Bunny` поддерживает большое количество разных опций, в `Sqamqp::Config` определны только `log_file` и `log_level`, но при необходимости можно расширить

#### Список опций Bunny: 

http://reference.rubybunny.info/Bunny/Session.html

```

Options Hash (connection_string_or_opts):
:host (String) — default: "127.0.0.1" — Hostname or IP address to connect to
:hosts (Array<String>) — default: ["127.0.0.1"] — list of hostname or IP addresses to select hostname from when connecting
:addresses (Array<String>) — default: ["127.0.0.1:5672"] — list of addresses to select hostname and port from when connecting
:port (Integer) — default: 5672 — Port RabbitMQ listens on
:username (String) — default: "guest" — Username
:password (String) — default: "guest" — Password
:vhost (String) — default: "/" — Virtual host to use
:heartbeat (Integer) — default: 600 — Heartbeat interval. 0 means no heartbeat.
:network_recovery_interval (Integer) — default: 4 — Recovery interval periodic network recovery will use. This includes initial pause after network failure.
:tls (Boolean) — default: false — Should TLS/SSL be used?
:tls_cert (String) — default: nil — Path to client TLS/SSL certificate file (.pem)
:tls_key (String) — default: nil — Path to client TLS/SSL private key file (.pem)
:tls_ca_certificates (Array<String>) — Array of paths to TLS/SSL CA files (.pem), by default detected from OpenSSL configuration
:verify_peer (String) — default: true — Whether TLS peer verification should be performed
:tls_version (Keyword) — default: negotiated — What TLS version should be used (:TLSv1, :TLSv1_1, or :TLSv1_2)
:continuation_timeout (Integer) — default: 15000 — Timeout for client operations that expect a response (e.g. Queue#get), in milliseconds.
:connection_timeout (Integer) — default: 5 — Timeout in seconds for connecting to the server.
:hosts_shuffle_strategy (Proc) — A Proc that reorders a list of host strings, defaults to Array#shuffle
:logger (Logger) — The logger. If missing, one is created using :log_file and :log_level.
:log_file (IO, String) — The file or path to use when creating a logger. Defaults to STDOUT.
:logfile (IO, String) — DEPRECATED: use :log_file instead. The file or path to use when creating a logger. Defaults to STDOUT.
:log_level (Integer) — The log level to use when creating a logger. Defaults to LOGGER::WARN
:automatically_recover (Boolean) — default: true — Should automatically recover from network failures?
:recovery_attempts (Integer) — default: nil — Max number of recovery attempts, nil means forever
:reset_recovery_attempts_after_reconnection (Integer) — default: true — Should recovery attempt counter be reset after successful reconnection? When set to false, the attempt counter will last through the entire lifetime of the connection object.
:recover_from_connection_close (Boolean) — default: true — Should this connection recover after receiving a server-sent connection.close (e.g. connection was force closed)?
```
