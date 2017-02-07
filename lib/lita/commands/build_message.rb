class BuildMessage < PowerTypes::Command.new(:entry, :previous_entries)
  def perform
    use_count = @previous_entries.count + 1
    data = GetGemInfo.for(name: @entry.gem_name) || { description: "No sé lo que hace esta gema..." }

    this_entry_msg = %Q(
*#{@entry.user}* incluyó en *#{@entry.project}* la gema:\n   • `#{@entry.gem_name}` #{data[:uri]}
>_#{data[:description]}_
• Es la *#{use_count}º vez* que se usa en Platanus.
)
    use_history_msg =
        case use_count
          when 0..1
            ""
          when 2
            "• *Uso anterior:* #{entry_phrase(@previous_entries.first)}"
          else
            "• *Últimos usos:* #{entry_phrase(@previous_entries[0])}, #{entry_phrase(@previous_entries[1])}"
        end

    this_entry_msg + use_history_msg + "\n"
  end

  def entry_phrase(_entry)
    "#{_entry.user} en '#{_entry.project}' (#{_entry.date.strftime("%b %Y")})"
  end
end
