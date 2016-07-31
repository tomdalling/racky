require 'json'

module LIF
  module JSON

    class Converter
      def self.convert(lif_document)
        new(lif_document).send(:json)
      end

      private

      attr_reader :lif_document

      def initialize(lif_document)
        @lif_document = lif_document
      end

      def json
        ::JSON.generate(document_obj(lif_document))
      end

      def document_obj(doc)
        {
          scenes: doc.scenes.map{ |s| scene_obj(s) },
        }
      end

      def scene_obj(scene)
        {
          paragraphs: scene.paragraphs.map{ |p| para_obj(p) }
        }
      end

      def para_obj(para)
        {
          style: para.style.to_h,
          runs: para.runs.map{ |r| run_obj(r) },
        }
      end

      def run_obj(run)
        {
          style: run.style.to_h,
          lines: run.lines.map{ |l| line_obj(l) }
        }
      end

      def line_obj(line)
        case line
        when String then line
        when LIF::LineBreak then nil
        else fail("Unhandled line obj to JSON: #{line.inspect}")
        end
      end

    end

    class Parser
      def self.parse(json)
        new(json).send(:lif_document)
      end

      private

      attr_reader :json

      def initialize(json)
        @json = json
      end

      def lif_document
        doc_obj = ::JSON.parse(json)
        LIF::Document.with(
          scenes: doc_obj['scenes'].map{ |s| scene(s) }
        )
      end

      def scene(scene_obj)
        LIF::Scene.with(
          paragraphs: scene_obj['paragraphs'].map{ |p| paragraph(p) }
        )
      end

      def paragraph(para_obj)
        LIF::Paragraph.with(
          style: from_hash(LIF::ParagraphStyle, para_obj['style']),
          runs: para_obj['runs'].map{ |r| run(r) }
        )
      end

      def run(run_obj)
        LIF::Run.with(
          style: from_hash(LIF::RunStyle, run_obj['style']),
          lines: run_obj['lines'].map{ |l| line(l) }
        )
      end

      def line(line_obj)
        case line_obj
        when String then line_obj
        when nil then LIF::LINE_BREAK
        else fail("Unhandled JSON line value: #{line_obj.inspect}")
        end
      end

      def from_hash(klass, hash)
        hash.keys.each do |key|
          hash[key.to_sym] = hash.delete(key)
        end
        klass.with(hash)
      end
    end

  end
end
