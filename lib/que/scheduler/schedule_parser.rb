require 'yaml'
require 'backports/2.4.0/hash/compact'

require_relative 'defined_job'

module Que
  module Scheduler
    module ScheduleParser
      QUE_SCHEDULER_CONFIG_LOCATION =
        ENV.fetch('QUE_SCHEDULER_CONFIG_LOCATION', 'config/que_schedule.yml')

      class << self
        def defined_jobs
          @defined_jobs ||= YAML.load_file(QUE_SCHEDULER_CONFIG_LOCATION).map do |k, v|
            Que::Scheduler::DefinedJob.new(
              {
                name: k,
                job_class: v['class'] || k,
                queue: v['queue'],
                args: v['args'],
                priority: v['priority'],
                cron: v['cron'],
                schedule_type: v['schedule_type'] || DefinedJob::SCHEDULE_TYPE_DEFAULT
              }.compact
            )
          end
        end
      end
    end
  end
end
