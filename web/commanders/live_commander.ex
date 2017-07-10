defmodule DrabPoc.LiveCommander do
  require IEx
  require Logger

  use Drab.Commander, modules: [Drab.Live]

  def uppercase(socket, sender) do
    text = sender.params["text_to_uppercase"]
    poke socket, text: String.upcase(text)
  end

  def lowercase(socket, sender) do
    text = sender.params["text_to_uppercase"]
    poke socket, text: String.downcase(text)
  end

  def replace_list(socket, _sender) do
    Drab.Live.poke socket, users: ["Mścisław", "Bożydar", "Mściwój", "Bogumił", "Mirmił"]
  end

  def replace_title(socket, _sender) do
    Drab.Live.poke socket, title: "New, better Title"
  end

  def add_to_list(socket, _sender) do
    users = Drab.Live.peek(socket, :users)
    Drab.Live.poke socket, users: users ++ ["Hegemon"]
  end

  def clicked_sleep_button(socket, sender) do
    button_no = sender["data"]["sleep"] |> String.to_integer()
    
    cl = peek socket, :sleep_button_classes
    poke socket, sleep_button_classes: %{cl | button_no => "btn-danger"}

    Process.sleep(button_no * 1000)
    
    cl = peek socket, :sleep_button_classes
    poke socket, sleep_button_classes: %{cl | button_no => "btn-primary"}    
  end

  def run_async_tasks(socket, _sender) do
    {:ok, async_task_classes} = Agent.start_link(fn -> for i <- 1..54, into: %{}, do: {i, "danger"} end)
    poke socket, async_task_label: "danger", async_task_status: "running", 
      async_task_classes: Agent.get(async_task_classes, &(&1))

    tasks = Enum.map(1..54, fn(i) -> Task.async(fn -> 
        Process.sleep(:rand.uniform(4000)) # simulate real work
        Agent.update(async_task_classes, fn state -> %{state | i => "success"} end)
        poke socket, async_task_classes: Agent.get(async_task_classes, &(&1))
      end)
    end)

    begin_at = :os.system_time(:millisecond)
    Enum.each(tasks, fn(task) -> Task.await(task) end)
    end_at = :os.system_time(:millisecond)
    Agent.stop(async_task_classes)
    
    poke socket, async_task_label: "success", async_task_status: 
      "finished in #{(end_at - begin_at)/1000} seconds"
  end

  def perform_long_process(socket, _sender) do
    poke socket, progress_bar_class: "progress-bar-danger", long_process_button_text: "Processing..."

    steps = :rand.uniform(100)
    for i <- 1..steps do
      Process.sleep(:rand.uniform(500)) #simulate real work
      poke socket, bar_width: Float.round(i * 100 / steps, 2)
    end

    poke socket, progress_bar_class: "progress-bar-success", long_process_button_text: "Click me to restart"
  end

  def changed_label(socket, sender) do
    poke socket, label: sender["value"]
  end

  def enlage_your_button_now(socket, _sender) do
    poke socket, button_height: peek(socket, :button_height) + 2
  end
end
