

defmodule Fib do
  def fib_calc(n) do
  	if (n<=2) do
  		1
  	else
      #fib_calc(n-1) + fib_calc(n-2)
      getFibNum(n)
  	end
  end

  def getFibNum(n) do
    fibList = helper(n,[0,1])
    Enum.at(fibList, n)
  end

  def helper(n, list) do
    if (n<2) do
      Enum.take list, n
    end
    if (n>=2) do
      helper(n-2,list)
    end
    if (n==0) do
      list
    else
      helper(n-1,list ++ [Enum.at(list, -1) + Enum.at(list, -2)])
    end
  end


  def server(caller) do
    send(caller, {:ready, self()})
    receive do
       {:compute, n, client} ->
         result = fib_calc(n)
         send(client, {:answer, n, result})
         server(caller)
       {:shutdown} -> exit(:normal)
    end
  end

end


server_pid = spawn(Fib, :server, [self()])

#sample test
send(server_pid,{:compute, 6, self()})


receive do
  {:answer, n, result} -> IO.puts("The result of Fib #{n} is #{result}")
  after 500 -> IO.puts("No one there it seems...")
end



defmodule Scheduler do
	def start(num_servers,job_list) do
    IO.puts("Initial job list...#{inspect job_list, charlists: :as_lists}")
    for _x <- 1..num_servers do
      spawn(Fib, :server, [self()])
    end
    run(num_servers, job_list, [])
	end

  def run(num_servers, job_list, result_list) do
    if num_servers == 0 do
      IO.puts("Result list is ...#{inspect result_list, charlists: :as_lists}")
    else
      receive do
        {:ready, server_pid} ->
          if (length(job_list) == 0) do
            send(server_pid,{:shutdown})
            run(num_servers - 1, job_list, result_list)
          else
            n = hd(job_list)
            send(server_pid, {:compute, n, self()})
            run(num_servers,tl(job_list),result_list)
          end
        {:answer, _n, result} ->
          result_list = [result | result_list]
          run(num_servers,job_list,result_list)
      end
    end
  end

end

#sample test
scheduler = spawn(Scheduler, :start, [3,[3,4,5]])
