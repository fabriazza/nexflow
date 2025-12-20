["Elettricità", "Gas", "Acqua"].each do |utility_type_name|
  UtilityType.find_or_create_by!(name: utility_type_name)
end
