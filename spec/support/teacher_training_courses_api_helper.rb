module TeacherTrainingCoursesApiHelper
  DEFAULT_PROVIDERS = FactoryBot.build_list(:teacher_training_courses_provider, 5)

  def stub_providers(providers = nil)
    # Use the default randomly generated providers, unless some have been given
    providers ||= DEFAULT_PROVIDERS

    response = {
      data: providers,
      links: {
        prev: nil,
        next: nil,
      },
      meta: {
        count: providers.count,
      },
    }

    stub_request(:get, "#{TeacherTrainingCourses::ApiClient::BASE_URL}/recruitment_cycles/2024/providers").
      to_return(
        status: 200,
        headers: {"Content-Type" => "application/vnd.api+json"},
        body: response.to_json
      )
  end
end
