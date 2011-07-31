class Abingo::Alternative
  include Mongoid::Document  

  field :experiment_id, :type => Fixnum
  field :content
  field :lookup, :type => String, :limit => 32
  field :weight, :type => Fixnum, :default => 1
  field :participants, :type => Fixnum, :default => 0
  field :conversions, :type => Fixnum, :default => 0


  index :experiment_id
  index :lookup

  
  include Abingo::ConversionRate




  belongs_to :experiment, :class_name => "Abingo::Experiment"
  attr_accessible :content, :weight, :lookup
  # serialize :content

  def self.calculate_lookup(test_name, alternative_name)
    Digest::MD5.hexdigest(Abingo.salt + test_name + alternative_name.to_s)
  end

  def self.score_conversion(test_name)
    viewed_alternative = Abingo.find_alternative_for_user(test_name,
      Abingo::Experiment.alternatives_for_test(test_name))
    # self.update_all("conversions = conversions + 1", :lookup => self.calculate_lookup(test_name, viewed_alternative))
        
    self.where(:lookup => self.calculate_lookup(test_name, viewed_alternative)).each do |alternative|
      alternative.update_attribute(:conversions, alternative.conversions + 1 )
    end
    
  end

  def self.score_participation(test_name)
    viewed_alternative = Abingo.find_alternative_for_user(test_name,
      Abingo::Experiment.alternatives_for_test(test_name))
    
    self.where(:lookup => self.calculate_lookup(test_name, viewed_alternative)).each do |alternative|
      alternative.update_attribute(:participants, alternative.participants + 1 )
    end
  end

end