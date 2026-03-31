# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Affect
        module Emotion
          module Runners
            module Valence
              include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers, false) &&
                                                          Legion::Extensions::Helpers.const_defined?(:Lex, false)

              def evaluate_valence(signal:, source_type: :ambient, deadline: nil, domain: nil, **)
                baseline = emotion_baseline

                urgency_raw = compute_urgency(signal, source_type, deadline)
                importance_raw = compute_importance(signal, domain)
                novelty_raw = compute_novelty(signal)
                familiarity_raw = compute_familiarity(domain)

                valence = Helpers::Valence.new_valence(
                  urgency:     baseline.normalize(urgency_raw, :urgency),
                  importance:  baseline.normalize(importance_raw, :importance),
                  novelty:     baseline.normalize(novelty_raw, :novelty),
                  familiarity: baseline.normalize(familiarity_raw, :familiarity)
                )

                # Update baselines with raw scores
                Helpers::Valence::DIMENSIONS.each do |dim|
                  raw = { urgency: urgency_raw, importance: importance_raw,
                          novelty: novelty_raw, familiarity: familiarity_raw }[dim]
                  baseline.update(dim, raw)
                end

                magnitude = Helpers::Valence.magnitude(valence)
                dominant = Helpers::Valence.dominant_dimension(valence)
                log.debug("[emotion] valence: source=#{source_type} magnitude=#{magnitude.round(2)} dominant=#{dominant} " \
                          "u=#{valence[:urgency].round(2)} i=#{valence[:importance].round(2)} " \
                          "n=#{valence[:novelty].round(2)} f=#{valence[:familiarity].round(2)}")

                {
                  valence:            valence,
                  magnitude:          magnitude,
                  dominant_dimension: dominant
                }
              end

              def aggregate_valences(valences:, **)
                aggregated = Helpers::Valence.aggregate(valences)
                arousal = Helpers::Valence.compute_arousal(valences)
                dominant = Helpers::Valence.dominant_dimension(aggregated)

                log.debug("[emotion] aggregate: count=#{valences.size} arousal=#{arousal.round(2)} dominant=#{dominant}")
                {
                  aggregate: aggregated,
                  arousal:   arousal,
                  dominant:  dominant,
                  count:     valences.size
                }
              end

              def modulate_attention(base_salience:, valence:, **)
                modulated = Helpers::Valence.modulate_salience(base_salience, valence)
                boost = modulated - base_salience
                log.debug("[emotion] attention modulation: base=#{base_salience.round(2)} modulated=#{modulated.round(2)} boost=#{boost.round(2)}")
                { original: base_salience, modulated: modulated, boost: boost }
              end

              def compute_arousal(valences:, **)
                arousal = Helpers::Valence.compute_arousal(valences)
                log.debug("[emotion] arousal=#{arousal.round(2)} from #{valences.size} valences")
                { arousal: arousal }
              end

              def evaluate_partner_absence(consecutive_misses: 1, **)
                importance = Helpers::Valence.absence_importance(consecutive_misses)

                valence = Helpers::Valence.new_valence(
                  urgency:     0.2,
                  importance:  importance,
                  novelty:     0.1,
                  familiarity: 0.8
                )

                magnitude = Helpers::Valence.magnitude(valence)
                dominant = Helpers::Valence.dominant_dimension(valence)

                log.debug("[emotion] partner_absence: misses=#{consecutive_misses} " \
                          "importance=#{importance.round(2)} magnitude=#{magnitude.round(2)}")

                { valence: valence, magnitude: magnitude, dominant_dimension: dominant,
                  event: :partner_absence, consecutive_misses: consecutive_misses }
              end

              def raise_urgency_for_knowledge_vulnerability(domains_at_risk:, severity: :warning, urgency_boost: 0.3, **)
                boost = severity.to_sym == :critical ? [urgency_boost * 1.5, 1.0].min : urgency_boost.to_f
                signal = { urgency_hint: boost, domain_weight: 0.6, impact_scope: 0.5,
                           outcome_severity: boost, novelty_score: 0.3 }
                result = evaluate_valence(signal: signal, source_type: :mesh_priority)

                log.info("[emotion] knowledge_vulnerability urgency raised: domains=#{Array(domains_at_risk).join(',')} " \
                         "severity=#{severity} boost=#{boost.round(2)} urgency=#{result[:valence][:urgency].round(2)}")

                result.merge(event: :knowledge_vulnerability, domains_at_risk: Array(domains_at_risk), urgency_boost: boost)
              end

              private

              def emotion_baseline
                @emotion_baseline ||= Helpers::Baseline.new
              end

              def compute_urgency(signal, source_type, deadline)
                deadline_urgency = 0.0
                if deadline
                  remaining = [(deadline - Time.now.utc).to_f, 0.0].max
                  max_window = 86_400.0 # 24 hours
                  deadline_urgency = Helpers::Valence.clamp(1.0 - (remaining / max_window))
                end

                source_urgency = Helpers::Valence::SOURCE_URGENCY.fetch(source_type, 0.1)

                pattern_urgency = signal.is_a?(Hash) ? (signal[:urgency_hint] || 0.0) : 0.0

                (deadline_urgency * 0.5) + (source_urgency * 0.3) + (pattern_urgency * 0.2)
              end

              def compute_importance(signal, _domain)
                domain_weight = signal.is_a?(Hash) ? (signal[:domain_weight] || 0.5) : 0.5
                impact_scope = signal.is_a?(Hash) ? (signal[:impact_scope] || 0.3) : 0.3
                reversibility = signal.is_a?(Hash) ? (signal[:reversibility] || 0.5) : 0.5
                outcome_severity = signal.is_a?(Hash) ? (signal[:outcome_severity] || 0.3) : 0.3

                (domain_weight * 0.3) + (impact_scope * 0.2) +
                  ((1.0 - reversibility) * 0.25) + (outcome_severity * 0.25)
              end

              def compute_novelty(signal)
                signal.is_a?(Hash) ? (signal[:novelty_score] || 0.5) : 0.5
              end

              def compute_familiarity(domain)
                signal_count = @domain_counts&.fetch(domain, 0) || 0
                Helpers::Valence.clamp(signal_count.to_f / Helpers::Valence::FAMILIARITY_SATURATION)
              end
            end
          end
        end
      end
    end
  end
end
