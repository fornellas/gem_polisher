class GemPolisher
  # test task
  class TestTask < Task
    def create_task
      desc 'Run all tests.'
      task :test
    end
  end
end
