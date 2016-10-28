class BuildMessage < PowerTypes::Command.new(:entry, :previous_entries)
  def perform
    use_count = @previous_entries.count + 1

    this_entry_msg = %Q(
    #{@entry.user} incluyó la gema '#{@entry.gem_name}' en el proyecto #{@entry.project}.
    Es la #{use_count}º vez que se usa en Platanus.
  )
    use_history_msg =
        case use_count
          when 0..1
            ""
          when 2
            "La otra vez fue #{entry_phrase(@previous_entries.first)}"
          when 3
            "Las otras 2 veces fueron #{entry_phrase(@previous_entries[0])}, y también #{entry_phrase(@previous_entries[1])}"
          else
            "Las últimas 2 veces fueron #{entry_phrase(@previous_entries[0])}, y #{entry_phrase(@previous_entries[1])}"
        end

    this_entry_msg + use_history_msg
  end

  def entry_phrase(_entry)
    "#{_entry.user} en '#{_entry.project}' (#{_entry.date.strftime("%b %Y")})"
  end
end
