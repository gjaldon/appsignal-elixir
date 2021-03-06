defmodule Appsignal.TransactionRegistry do
  @moduledoc """

  Internal module which keeps a registry of the transaction handles
  linked to their originating process.

  This is used on various places to link a calling process to its transaction.
  For instance, the `Appsignal.ErrorHandler` module uses it to be able to
  complete the transaction in case the originating process crashed.

  The transactions are stored in an ETS table (with
  `{:write_concurrency, true}`, so no bottleneck is created); and the
  originating process is monitored to clean up the ETS table when the
  process has finished.

  """

  use GenServer

  require Logger

  @table :"$appsignal_transaction_registry"

  alias Appsignal.Transaction

  @spec start_link :: {:ok, pid}
  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  Register the current process as the owner of the given transaction.
  """
  @spec register(Transaction.t()) :: :ok
  def register(transaction) do
    pid = self()

    if Appsignal.Config.active?() && registry_alive?() do
      monitor_reference = GenServer.call(__MODULE__, {:monitor, pid})
      true = :ets.insert(@table, {pid, transaction, monitor_reference})
      :ok
    else
      nil
    end
  end

  @doc """
  Given a process ID, return its associated transaction.
  """
  @spec lookup(pid) :: Transaction.t() | nil
  def lookup(pid) do
    case Appsignal.Config.active?() && registry_alive?() && :ets.lookup(@table, pid) do
      [{^pid, %Transaction{} = transaction, _}] -> transaction
      [{^pid, %Transaction{} = transaction}] -> transaction
      [{^pid, :ignore}] -> :ignored
      _ -> nil
    end
  end

  @spec lookup(pid, boolean) :: Transaction.t() | nil | :removed
  @doc false
  def lookup(pid, return_removed) do
    IO.warn(
      "Appsignal.TransactionRegistry.lookup/2 is deprecated. Use Appsignal.TransactionRegistry.lookup/1 instead"
    )

    case registry_alive?() && :ets.lookup(@table, pid) do
      [{^pid, :removed}] ->
        case return_removed do
          false -> nil
          true -> :removed
        end

      [{^pid, transaction, _}] ->
        transaction

      [{^pid, transaction}] ->
        transaction

      false ->
        nil

      [] ->
        nil
    end
  end

  @doc """
  Unregister the current process as the owner of the given transaction.
  """
  @spec remove_transaction(Transaction.t()) :: :ok | {:error, :not_found} | {:error, :no_registry}
  def remove_transaction(%Transaction{} = transaction) do
    if registry_alive?() do
      GenServer.cast(__MODULE__, {:demonitor, transaction})
      GenServer.call(__MODULE__, {:remove, transaction})
    else
      {:error, :no_registry}
    end
  end

  @doc """
  Ignore a process in the error handler.
  """
  @spec ignore(pid()) :: :ok
  def ignore(pid) do
    if registry_alive?() do
      :ets.insert(@table, {pid, :ignore})
      :ok
    else
      {:error, :no_registry}
    end
  end

  @doc """
  Check if a progress is ignored.
  """
  @deprecated "Use Appsignal.TransactionRegistry.lookup/1 instead."
  @spec ignored?(pid()) :: boolean()
  def ignored?(pid) do
    case registry_alive?() && :ets.lookup(@table, pid) do
      [{^pid, :ignore}] -> true
      _ -> false
    end
  end

  defmodule State do
    @moduledoc false
    defstruct table: nil
  end

  def init([]) do
    table =
      :ets.new(@table, [:set, :named_table, {:keypos, 1}, :public, {:write_concurrency, true}])

    {:ok, %State{table: table}}
  end

  def handle_call({:remove, transaction}, _from, state) do
    reply =
      case pids_and_monitor_references(transaction) do
        [[_pid, _reference] | _] = pids_and_refs ->
          delete(pids_and_refs)

        [[_pid] | _] = pids ->
          delete(pids)

        [] ->
          {:error, :not_found}
      end

    {:reply, reply, state}
  end

  def handle_call({:monitor, pid}, _from, state) do
    monitor_reference = Process.monitor(pid)
    {:reply, monitor_reference, state}
  end

  def handle_cast({:demonitor, %Transaction{} = transaction}, state) do
    transaction
    |> pids_and_monitor_references()
    |> demonitor

    {:noreply, state}
  end

  def handle_info({:DOWN, _ref, :process, pid, _reason}, state) do
    # we give the error handler some time to process the error report
    Process.send_after(self(), {:delete, pid}, 5000)
    {:noreply, state}
  end

  def handle_info({:delete, pid}, state) do
    :ets.delete(@table, pid)
    {:noreply, state}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  defp delete([[pid, _] | tail]) do
    :ets.delete(@table, pid)
    delete(tail)
  end

  defp delete([[pid] | tail]) do
    :ets.delete(@table, pid)
    delete(tail)
  end

  defp delete([]), do: :ok

  defp demonitor([[_, reference] | tail]) do
    Process.demonitor(reference)
    demonitor(tail)
  end

  defp demonitor([_ | tail]), do: demonitor(tail)
  defp demonitor([]), do: :ok

  defp registry_alive? do
    pid = Process.whereis(__MODULE__)
    !is_nil(pid) && Process.alive?(pid)
  end

  defp pids_and_monitor_references(transaction) do
    :ets.match(@table, {:"$1", transaction, :"$2"}) ++ :ets.match(@table, {:"$1", transaction})
  end
end
