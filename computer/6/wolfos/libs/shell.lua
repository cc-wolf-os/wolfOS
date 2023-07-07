function run()
    shell.run(read(nil,nil,shell.completeProgram))
end

return {run=run}