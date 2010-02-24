# FIXME: Find better solution to add partner_id to all finds for models that specify:
## class << self
##   alias_method_chain :find, :condition_cleansing
## end

# Adds Current partner to every find
ActiveRecord::Base.class_eval do
  class << self
    def set_condition(*args)
      index = args[1] ? 1 : 0
      if args[index][:conditions]
        if args[index][:conditions].is_a?(Array)
          args[index][:conditions][0] += " AND partner_id = ?"
          args[index][:conditions] << Partner.current.id
        elsif args[index][:conditions].is_a?(Hash)
          args[index][:conditions][:partner_id] = Partner.current.id
        else
          args[index][:conditions] += " AND partner_id = #{Partner.current.id}"
        end
      else
        if args[index].is_a?(Hash)
          args[index][:conditions] = ["partner_id = ?", Partner.current.id]
        else
          args[index] << "partner_id = #{Partner.current.id}"
        end
      end
    end

    def find_with_condition_cleansing(*args)
      # logger.info "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"
      # logger.info *args.inspect
      # logger.info "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"
      set_condition(*args) if Partner.current
      # logger.info "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"
      # logger.info *args.inspect
      # logger.info "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"
      find_without_condition_cleansing(*args)
    end
  end
end

# SHOULD BE INSIDE MODEL:
##### FFJ: TRYING TO HACK DEFAULT SCOPE TO BE ABLE TO SET PARTNER INTO EVERY FIND
##### 
## Doesn't seem to work as default_scope doesn't allow Proc
#####
#####
# default_scope do 
#    lambda {:conditions => "partner_id = #{Thread.current[:partner]}"}
# end

# default_scope do
#   { :conditions => ["partner_id < ?", Partner.find(current_partner)] }
# end

# Proc.new { default_scope :conditions => ["partner_id = ?",  Time.now] }

# if Partner.current
#   # default_scope :conditions => {:partner_id => Partner.find_by_short_name('2020')} # Partner.current.id
  # default_scope :conditions => {:partner_id => }
#   # default_scope(lambda { { :conditions => ['partner_id < ?', current_partner.id] } })
# end

# default_scope :conditions => {:partner_id => Partner.find()}
# default_scope :conditions => {:partner_id => Partner.find_by_short_name(request.subdomains.first )} # Partner.current.id
#### END FFJ
