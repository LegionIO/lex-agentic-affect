# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Affect
        module Reappraisal
          module Helpers
            class ReappraisalEngine
              include Constants

              MECHANICAL_REAPPRAISALS = {
                reinterpretation:    {
                  negative:        'This situation may have aspects that are not immediately apparent. Consider alternative explanations.',
                  highly_negative: 'Strong negative reactions often signal something important. Examine what underlying need is unmet.',
                  neutral:         'A balanced perspective reveals both challenges and opportunities in this situation.'
                },
                distancing:          {
                  negative:        'Viewed from a broader timeline, this event occupies a small portion of overall experience.',
                  highly_negative: 'In the larger context of ongoing goals and relationships, this moment will pass.',
                  neutral:         'Stepping back reveals this is one event among many.'
                },
                benefit_finding:     {
                  negative:        'Difficult experiences often contain lessons that become apparent with reflection.',
                  highly_negative: 'Even significant setbacks can reveal strengths and areas for growth.',
                  neutral:         'There may be unexpected value in examining this experience closely.'
                },
                acceptance:          {
                  negative:        'Acknowledging this experience as it is, without resistance, creates space for response.',
                  highly_negative: 'Some experiences cannot be changed, only accepted and integrated.',
                  neutral:         'This experience is acknowledged and integrated without judgment.'
                },
                normalizing:         {
                  negative:        'Many others have faced similar situations. This reaction is a common and understandable response.',
                  highly_negative: 'Intense responses to difficult events are a natural part of experience, not a sign of weakness.',
                  neutral:         'This situation falls within the normal range of experience.'
                },
                perspective_taking:  {
                  negative:        'Considering this from another vantage point reveals aspects that were not initially visible.',
                  highly_negative: 'Seeing through a different lens can transform how a significant event is understood.',
                  neutral:         'Multiple perspectives offer a fuller picture of what is happening.'
                },
                temporal_distancing: {
                  negative:        'Looking back from the future, this moment is likely to appear smaller and more manageable.',
                  highly_negative: 'Even the most difficult moments recede with time. This too will become part of a larger story.',
                  neutral:         'In the fullness of time, the significance of this event will become clearer.'
                }
              }.freeze

              attr_reader :events, :reappraisal_log

              def initialize
                @events          = {}
                @reappraisal_log = []
              end

              def register_event(content:, valence:, intensity:, appraisal:)
                event = EmotionalEvent.new(
                  content:   content,
                  valence:   valence,
                  intensity: intensity,
                  appraisal: appraisal
                )

                @events.shift while @events.size >= Constants::MAX_EVENTS
                @events[event.id] = event
                event
              end

              def reappraise(event_id:, strategy:, new_appraisal:)
                event = @events[event_id]
                return { success: false, reason: :event_not_found } unless event
                return { success: false, reason: :invalid_strategy } unless Constants.valid_strategy?(strategy)

                old_valence   = event.current_valence
                old_intensity = event.current_intensity

                change = event.reappraise!(strategy: strategy, new_appraisal: new_appraisal)

                log_entry = {
                  event_id:         event_id,
                  strategy:         strategy,
                  valence_change:   (event.current_valence - old_valence).round(10),
                  intensity_change: (old_intensity - event.current_intensity).round(10),
                  applied_at:       Time.now.utc
                }

                @reappraisal_log.shift while @reappraisal_log.size >= Constants::MAX_REAPPRAISALS
                @reappraisal_log << log_entry

                {
                  success:           true,
                  event_id:          event_id,
                  strategy:          strategy,
                  change:            change.round(10),
                  current_valence:   event.current_valence.round(10),
                  current_intensity: event.current_intensity.round(10)
                }
              end

              def auto_reappraise(event_id:)
                event = @events[event_id]
                return { success: false, reason: :event_not_found } unless event

                strategy = select_strategy(event)
                new_appraisal = self.class.mechanical_appraisal(strategy, event.current_valence)
                reappraise(event_id: event_id, strategy: strategy, new_appraisal: new_appraisal)
              end

              def negative_events
                @events.values.select(&:negative?)
              end

              def intense_events
                @events.values.select(&:intense?)
              end

              def most_regulated(limit: 5)
                @events.values
                       .sort_by { |e| -e.regulation_amount }
                       .first(limit)
              end

              def strategy_effectiveness
                grouped = @reappraisal_log.group_by { |entry| entry[:strategy] }
                grouped.transform_values do |entries|
                  changes = entries.map { |e| e[:valence_change] }
                  changes.sum.to_f / changes.size
                end
              end

              def average_regulation
                return 0.0 if @events.empty?

                total = @events.values.sum(&:regulation_amount)
                (total / @events.size).round(10)
              end

              def overall_regulation_ability
                return 0.0 if @events.empty?

                regulated_count = @events.values.count { |e| e.regulation_amount > 0.0 }
                mean_reg        = average_regulation
                coverage        = regulated_count.to_f / @events.size

                ((mean_reg + coverage) / 2.0).round(10)
              end

              def reappraisal_report
                {
                  total_events:               @events.size,
                  total_reappraisals:         @reappraisal_log.size,
                  negative_events:            negative_events.size,
                  intense_events:             intense_events.size,
                  average_regulation:         average_regulation,
                  overall_regulation_ability: overall_regulation_ability,
                  strategy_effectiveness:     strategy_effectiveness,
                  most_regulated:             most_regulated(limit: 3).map(&:to_h)
                }
              end

              def to_h
                {
                  events:                     @events.transform_values(&:to_h),
                  reappraisal_log:            @reappraisal_log,
                  average_regulation:         average_regulation,
                  overall_regulation_ability: overall_regulation_ability,
                  strategy_effectiveness:     strategy_effectiveness
                }
              end

              def self.valence_bracket(valence)
                if valence < -0.6
                  :highly_negative
                elsif valence < 0.0
                  :negative
                else
                  :neutral
                end
              end

              def self.mechanical_appraisal(strategy, valence)
                bracket  = valence_bracket(valence)
                strategy = strategy.to_sym
                brackets = MECHANICAL_REAPPRAISALS[strategy]
                return "Reappraised via #{strategy}" unless brackets

                brackets[bracket] || brackets.values.first || "Reappraised via #{strategy}"
              end

              private

              def select_strategy(event)
                if event.negative? && event.intense?
                  :distancing
                elsif event.negative?
                  :reinterpretation
                elsif event.intense?
                  :temporal_distancing
                else
                  :benefit_finding
                end
              end
            end
          end
        end
      end
    end
  end
end
