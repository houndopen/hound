require 'spec_helper'

describe PullRequest, '#valid?' do
  let(:github_id) { '12345' }
  let(:payload) { { 'repository' => { 'id' => github_id } } }
  let(:pull_request) { PullRequest.new(payload) }

  context 'with inactive repo' do
    it 'returns false' do
      create(:repo, github_id: github_id, active: false)

      expect(pull_request).not_to be_valid
    end
  end

  context 'with active repo' do
    context 'with synchronize action' do
      it 'returns true' do
        payload['action'] = 'synchronize'
        create(:active_repo, github_id: github_id)

        expect(pull_request).to be_valid
      end
    end

    context 'with opened action' do
      it 'returns true' do
        payload['action'] = 'opened'
        create(:active_repo, github_id: github_id)

        expect(pull_request).to be_valid
      end
    end

    context 'with closed action' do
      it 'returns false' do
        payload['action'] = 'closed'
        create(:active_repo, github_id: github_id)

        expect(pull_request).not_to be_valid
      end
    end
  end
end

describe PullRequest, '#files' do
  let(:fixture_file) { 'spec/support/fixtures/pull_request_payload.json' }
  let(:payload) { JSON.parse(File.read(fixture_file)) }

  it 'returns an array of modified files' do
    pull_request_files = [OpenStruct.new, OpenStruct.new]
    file_contents = OpenStruct.new(content: Base64.encode64('blah'))
    api = double(
      :github_api,
       pull_request_files: pull_request_files,
       file_contents: file_contents
    )
    GithubApi.stub(new: api)
    pull_request = PullRequest.new(payload)
    create(:active_repo, github_id: payload['repository']['id'])

    expect(pull_request).to have(2).files
    expect(api).to have_received(:pull_request_files).with('salbertson/life', 2)
  end

  it 'excludes removed files' do
    pull_request_files = [OpenStruct.new(status: 'removed'), OpenStruct.new]
    file_contents = OpenStruct.new(content: Base64.encode64('blah'))
    api = double(
      :github_api,
       pull_request_files: pull_request_files,
       file_contents: file_contents
    )
    GithubApi.stub(new: api)
    pull_request = PullRequest.new(payload)
    create(:active_repo, github_id: payload['repository']['id'])

    expect(pull_request).to have(1).files
    expect(pull_request.files.first).to be_a ModifiedFile
  end
end