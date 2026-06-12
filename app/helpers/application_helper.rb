module ApplicationHelper
  def status_badge_class(status)
    case status
    when "pending"     then "bg-yellow-100 text-yellow-800"
    when "in_progress" then "bg-blue-100 text-blue-800"
    when "completed"   then "bg-emerald-100 text-emerald-800"
    else                    "bg-gray-100 text-gray-700"
    end
  end

  def priority_badge_class(priority)
    case priority
    when "high"   then "bg-red-100 text-red-800"
    when "medium" then "bg-orange-100 text-orange-800"
    when "low"    then "bg-gray-100 text-gray-600"
    else               "bg-gray-100 text-gray-600"
    end
  end
end
