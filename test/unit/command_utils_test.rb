#!/usr/bin/env ruby


# ########################################################################## #
# Includes
# ########################################################################## #
require '../../lib/command_utils'


# ########################################################################## #
# Methods
# ########################################################################## #
include CommandUtils

run_command('sleep 15')
puts @pid, @process_status
