module CollectionsHelper
  def day_of_week_collection
    [
      [:sunday, localize_day_name(0)],
      [:monday, localize_day_name(1)],
      [:tuesday, localize_day_name(2)],
      [:wednesday, localize_day_name(3)],
      [:thursday, localize_day_name(4)],
      [:friday, localize_day_name(5)],
      [:saturday, localize_day_name(6)]
    ]
  end
end