puts "== Seeding Taskablanca data =================="

TaskAssignment.delete_all
ProjectMembership.delete_all
Task.delete_all
Project.delete_all
Session.delete_all
OrganizationMembership.delete_all
User.delete_all
Organization.delete_all

org1 = Organization.create!(name: "Hotwire Labs")
org2 = Organization.create!(name: "ActiveRecord Studios")

ada = User.create!(name: "Ada Lovelace", email_address: "ada@hotwirelabs.dev", password: "password")
alan = User.create!(name: "Alan Turing", email_address: "alan@hotwirelabs.dev", password: "password")
charles = User.create!(name: "Charles Babbage", email_address: "charles@hotwirelabs.dev", password: "password")
grace = User.create!(name: "Grace Hopper", email_address: "grace@activerecord.dev", password: "password")
donald = User.create!(name: "Donald Knuth", email_address: "donald@activerecord.dev", password: "password")
edsger = User.create!(name: "Edsger Dijkstra", email_address: "edsger@activerecord.dev", password: "password")

OrganizationMembership.create!(user: ada, organization: org1, role: :owner)
OrganizationMembership.create!(user: alan, organization: org1, role: :admin)
OrganizationMembership.create!(user: charles, organization: org1, role: :member)
OrganizationMembership.create!(user: grace, organization: org2, role: :owner)
OrganizationMembership.create!(user: donald, organization: org2, role: :admin)
OrganizationMembership.create!(user: edsger, organization: org2, role: :member)

projects = Project.create!([
  { title: "TurboBoard",        description: "A real-time Kanban powered by Hotwire.", organization: org1 },
  { title: "Stimulus Portal",   description: "A modern UI layer built with Stimulus and Turbo.", organization: org1 },
  { title: "ActiveSchema",      description: "Evolving database schemas with Rails generators.", organization: org2 },
  { title: "RailsRefactor Pro", description: "Refactor legacy apps to follow modern Rails conventions.", organization: org2 }
])

org1_users = [ ada, alan, charles ]
org2_users = [ grace, donald, edsger ]

projects.each do |project|
  project_users = if project.organization == org1
    org1_users.sample(2)
  else
    org2_users.sample(2)
  end
  project.users << project_users
end

statuses = %w[todo in_progress done]

project_tasks = {
  "TurboBoard" => [
    "Implement Turbo Stream updates",
    "Add inline task editing with Turbo Frames",
    "Style Kanban columns with Bootstrap",
    "Broadcast task status changes in real time",
    "Write system tests for task transitions"
  ],
  "Stimulus Portal" => [
    "Create Stimulus controllers for modal dialogs",
    "Refactor project forms to use Turbo Frames",
    "Add search filter for tasks",
    "Integrate FontAwesome icons",
    "Fix flicker issue on task updates"
  ],
  "ActiveSchema" => [
    "Define migration generator templates",
    "Implement reversible migrations",
    "Add validation for column changes",
    "Refactor schema DSL internals",
    "Write unit tests for migration parser"
  ],
  "RailsRefactor Pro" => [
    "Remove deprecated callbacks",
    "Convert legacy ERB templates to Turbo partials",
    "Add RuboCop and fix lint warnings",
    "Extract service objects for background jobs",
    "Improve ActiveRecord query performance"
  ]
}

projects.each do |project|
  project_tasks[project.title].each_with_index do |title, i|
    task = project.tasks.create!(
      title: title,
      description: "Task ##{i + 1} for #{project.title}: #{title.downcase}.",
      status: statuses.sample
    )

    user = project.users[i % project.users.size]
    task.users << user
  end
end

puts "== Seeding completed =========================="
