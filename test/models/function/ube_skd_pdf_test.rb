# -*- coding: utf-8 -*-
require 'test_helper'
require 'pp'
require "stringio"
require "postscript"
require "ps_ube_skd"
#require 'result_copy_data.rb'
class Function::UbeSkdPdfTest < ActiveSupport::TestCase
  #fixtures :ube_holydays,:ube_maintains,:ube_products,:ube_operations,:ube_plans,:ube_named_changes,:ube_change_times

  def setup
    @pdf = Pdf.new
    @pdf.out = PsUbeSkd.new(:paper => "A3l",:macro => :all) #StringIO.new("", 'r+')
  end

end

class Pdf
  include Function::UbeSkdPdf
  attr_accessor :out
  def to_s
    case @out
    when StringIO
      @out.rewind
      @out.read
    when PsUbeSkd
     # @out.close
      @out.page.join#(" ")
    end
  end
end
__END__
