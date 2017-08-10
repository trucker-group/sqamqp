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
Sqamqp::Connection.establish_connection
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
