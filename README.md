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
Sqamqp::Connection.connection_string #=> 'amqp://stage:stage@192.1681.1/vhost'
```


###  Публикация сообщений: 

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

