module JobsHelper

  def format_twz( twz )
    return twz.strftime("%D %T") unless twz.nil?
    ""
  end
end
