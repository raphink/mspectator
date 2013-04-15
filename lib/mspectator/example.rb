require 'mcollective'

module MSpectator
  module ExampleGroup
    include MCollective::RPC

    def subject
      self.class.top_level_description
    end

    def mc_clients
      @mc_clients ||= {}
    end

    def mc_client(agent)
      unless mc_clients.has_key? agent
        # Can't pass :progress_bar to rpcclient()?
        new = rpcclient(agent)
        new.progress = false
        mc_clients[agent] = new
      end
      mc_clients[agent]
    end

    def filtered_mc(agent, example)
      mc = mc_client(agent)
      apply_filters(mc, example)
    end

    def apply_filters (mc, example)
      classes = example.metadata[:classes] || []
      facts = example.metadata[:facts] || {}
      mc.compound_filter example.example_group.top_level_description
      unless classes.empty? and facts.empty?
        classes.each do |c|
          mc.class_filter c
        end
        facts.each do |f, v|
          mc.fact_filter f, v
        end
      end
      mc
    end
    
    def check_spec (example, action, values)
      spec_mc = filtered_mc('spec', example)
      passed = []
      failed = []
      spec_mc.check(:action => action, :values => values).each do |resp|
        if resp[:data][:passed]
          passed << resp[:sender]
        else
          failed << resp[:sender]
        end
      end
      return passed, failed
    end
    
    def get_fqdn (example)
      util_mc = self.mc_client('rpcutil')
      util_mc.progress = false
      util_mc = apply_filters util_mc, example
      fqdn = []
      util_mc.get_fact(:fact => 'fqdn').each do |resp|
        fqdn << resp[:data][:value]
      end
      fqdn
    end
  end
end
