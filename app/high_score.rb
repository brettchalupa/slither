module HighScore
  class << self
    def get(args)
      args.state.high_score
    end

    def load(args)
      args.state.high_score = args.gtk.read_file(file)&.chomp&.to_i || 0
    end

    def save(args, high_score)
      args.state.high_score = high_score
      args.gtk.write_file(
        file,
        high_score.to_s
      )
    end

    def file
      "high-score#{ debug? ? '-debug' : nil}.txt"
    end
  end
end
