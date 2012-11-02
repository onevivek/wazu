#!/usr/bin/env ruby


# ########################################################################## #
# Includes
# ########################################################################## #
# Note : require rubygems needed for optiflag
require 'rubygems'
require 'optiflag'
require File.join(File.dirname(__FILE__), "..", "..", "config", "environment")
require 'job_utils'


# ########################################################################## #
# Methods
# ########################################################################## #
include JobUtils

run_job_list([1,2,3])
