require 'thor'
require 'base'
require 'json'
require 'yaml'
require 'active_support/all'
require 'daemon_spawn'

module Bitcoin2Graphdb
  class Bitcoin2GraphdbDaemon < DaemonSpawn::Base
    def start(args)
      puts "Bitcoin2GraphdbDaemon start : #{Time.now}"
      migration = Bitcoin2Graphdb::Migration.new(args[0][:bitcoin2graphdb])
      migration.run
    end

    def stop
      puts "Bitcoin2GraphdbDaemon stop : #{Time.now}"
    end
  end


  class CLI < Thor
    class_option :pid, aliases: '-p', default: Dir.pwd + '/bitcoin2graphdb.pid', banner: '<pid file path>'
    class_option :log, aliases: '-l', default: Dir.pwd + '/bitcoin2graphdb.log', banner: '<log file path>'

    option :conf, aliases: '-c' , required: true, banner: '<configuration file path>'
    desc "start", "start bitcoin2graphdb daemon process"
    def start()
      conf = read_conf options[:conf]
      execute_daemon(options[:log], options[:pid], ['start', conf])
    end

    desc "stop", "stop bitcoin2graphdb daemon process"
    def stop
      execute_daemon(options[:log], options[:pid], ['stop'])
    end

    desc "status", "show bitcoin2graphdb daemon status"
    def status
      execute_daemon(options[:log], options[:pid], ['status'])
    end

    option :conf, aliases: '-c' , required: true, banner: '<configuration file path>'
    desc "restart", "restart bitcoin2graphdb daemon process"
    def restart()
      conf = read_conf options[:conf]
      execute_daemon(options[:log], options[:pid], ['restart', conf])
    end

    private
    def read_conf(conf_path)
      unless File.exists?(conf_path)
        raise ArgumentError.new(
                "configuration file[#{options[:conf]}] not specified or does not exist.")
      end
      YAML.load( File.read(options[:conf]) ).deep_symbolize_keys
    end

    def execute_daemon(log, pid, cmd_args)
      Bitcoin2Graphdb::Bitcoin2GraphdbDaemon.spawn!(
        { working_dir: Dir.pwd,
          log_file: File.expand_path(log),
          pid_file: File.expand_path(pid),
          sync_log: true,
          singleton: true},
        cmd_args)
    end

  end
end
