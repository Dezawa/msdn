# -*- coding: utf-8 -*-
class Delayed::Job < ActiveRecord::Base

  delegate :logger, :to=>"ActiveRecord::Base"
  set_table_name 'delayed_jobs'
  #object: LOAD;Hospital::Assign
  #method: :create_assign
  #args:
  # - 1
  # - 2013-02-01
  
  # enqueue
  def before(job)
    logger.debug("Delayed::Job#before #{job}")
  end
  def after(job)
    logger.debug("Delayed::Job#after #{job}")
  end
  # success(job)
  def error(job, exception)
    logger.debug("Delayed::Job#error job #{job} exception #{exception}")
  end
  def failure
    logger.debug("Delayed::Job#failure #{self}")
  end
  def failed(job) 
    logger.debug("Delayed::Job#failed job #{job}")
  end
end
